library(tidyverse)
library(LaplacesDemon)

I = 10000
J = 8

df = tibble(individual = rep(1:I, J+1),
            j = rep(0:J, I),
            epsilon = rep(0, I *(J+1))) %>% 
  mutate(p = 10 - j/2,
         x = 10 - j/10,
         xi = j/5,
         beta = 1,
         alpha = 1)

for(i in seq_along(df$epsilon)){
  df$epsilon[i] = revd(1)
}

df = df %>% 
  mutate(u = beta*x - alpha*p + xi + epsilon)


df %>% 
  arrange(individual, j) %>% 
  view()

chosen = df %>%
  group_by(individual) %>% 
  filter(u == max(u)) %>% 
  arrange(individual, j) %>% 
  ungroup()

## Is the market covered?

quantile(chosen$u) # yes

## Question 1 -------
# Aggregate shares ==> individual choice probabilities

table(chosen$j)/table(df$j)*100

