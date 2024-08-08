/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

#define TOKEN_STR_LEN_MAX 32
#define TOKENS_COUNT_MAX 32

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  TK_DEC,

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +",        TK_NOTYPE},     // spaces
  {"[0-9]+",    TK_DEC},        // decimal numbers
  {"\\+",       '+'},           // plus
  {"-",         '-'},           // minus
  {"\\*",       '*'},           // mul
  {"\\/",       '/'},           // div
  {"\\(",       '('},           // left bracket
  {"\\)",       ')'},           // right bracket
  {"==",        TK_EQ},         // equal
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[TOKEN_STR_LEN_MAX];
} Token;

static Token tokens[TOKENS_COUNT_MAX] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        // debug: print the rule matched to check the regex
        IFDEF(CONFIG_EXPR_DEBUG_INFO,
            Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);
        )

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
            case TK_NOTYPE:
                break;  // ignore space
            case TK_DEC: 
                tokens[nr_token].type = TK_DEC;
                memcpy(tokens[nr_token].str, substr_start, substr_len);
                tokens[nr_token].str[substr_len] = '\0';
                nr_token++;
                break;
            case '+':
                tokens[nr_token].type = '+';
                nr_token++;
                break;
            case '-':
                tokens[nr_token].type = '-';
                nr_token++;
                break;
            case '*':
                tokens[nr_token].type = '*';
                nr_token++;
                break;
            case '/':
                tokens[nr_token].type = '/';
                nr_token++;
                break;
            case '(':
                tokens[nr_token].type = '(';
                nr_token++;
                break;
            case ')':
                tokens[nr_token].type = ')';
                nr_token++;
                break;
            default: TODO();
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

    // debug: prinf the tokens to check the function of make_token()
    IFDEF(CONFIG_EXPR_DEBUG_INFO,
        for (int y = 0; y < nr_token; y++) {
            Log("tokens[%d].type = %d, tokens[%d].str = %s",y,tokens[y].type,y,tokens[y].str);
        }
    )

  return true;
}

int priority(int op) {
    switch (op) { 
        case '+':
        case '-':
            return 10; 
        case '*':
        case '/':
            return 15;
        default:
            return -1;
    }
}

// 1. confirm whether the expression is surrounded by a matched pair of parentheses
// 2. whether the expression is valid 
bool check_parentheses(int p, int q, bool *success) {
    bool valid_parentheses = true;    // default: true
    int flag = 0;
    // traversal the expression
    for (int index = p; index <= q; index++) {
        if (index == p) {
            if (tokens[index].type == '(') {
                flag++;
            }
            else if (tokens[index].type == ')') {
                flag--;
                valid_parentheses = false;
            }
            else {
                valid_parentheses = false;
            }
        }
        else if (index == q) {
            if (tokens[index].type == '(') {
                flag++;
                valid_parentheses = false;
            }
            else if (tokens[index].type == ')') {
                flag--;
            }
            else {
                valid_parentheses = false;
            }
        }
        else {
            if (tokens[index].type == '(') {
                flag++;
            }
            else if (tokens[index].type == ')') {
                flag--;
            }
        }

        if (index != q && flag == 0) {
            valid_parentheses = false;
        }
        else if (index == q && flag != 0) {
            *success = false;
        }
        else if (flag < 0) {
            *success = false;
        }
    }
    return valid_parentheses;
}

// get the main operator 
int get_main_operator(int p, int q, bool *success) {
    int mp_position = -1;
    int level = 0;
    for (int i = p; i <= q; i++) {
        if (tokens[i].type == '(') {
            level++;
        }
        else if (tokens[i].type == ')') {
            level--;
        }
        else if (level == 0 && priority(tokens[i].type) > 0 ) {
            if (mp_position == -1 || (priority(tokens[mp_position].type) >= priority(tokens[i].type))) {
            mp_position = i;
            }
        }
    }
    if (mp_position == -1) {
        *success = false;
        return 0;
    }
    return mp_position;
}

word_t eval(int p, int q, bool *success){
    word_t result = 0;  // default: 0
    if (p > q) {
        *success = false;   // bad expression
    }
    else if (p == q) {
        sscanf(tokens[p].str, "%d", &result);
    }
    else {
        bool valid_parentheses = check_parentheses(p, q, success);
        if (valid_parentheses && *success) {
            // the expression is surrounded by a matched pair of parentheses
            return eval(p+1, q-1, success);
        }
        else if (!valid_parentheses && *success) {
            // find main operator  
            int mp_position = get_main_operator(p, q, success);
            // divide and conquer
            switch (tokens[mp_position].type) {
                case '+': 
                    return eval(p, mp_position - 1, success) + eval(mp_position + 1, q, success);
                case '-': 
                    return eval(p, mp_position - 1, success) - eval(mp_position + 1, q, success);
                case '*':
                    return eval(p, mp_position - 1, success) * eval(mp_position + 1, q, success);
                case '/':
                    if (eval(mp_position + 1, q, success) == 0) {
                        *success = false;
                        printf("div by 0 !!!!\n");
                        return 0;
                    }
                    return eval(p, mp_position - 1, success) / eval(mp_position + 1, q, success);
        // unknow type: failed
        default: 
          return 0;
            }
        }
    }
    return result;
}

word_t expr(char *e, bool *success) {
    if (!make_token(e)) {
        *success = false;
        return 0;
    }

    /* TODO: Insert codes to evaluate the expression. */
    //   TODO();
    word_t result = eval(0, nr_token-1, success);
    return result;
}
