#Automated Web scarpping using rvest

#Parsing the HTML/XML files
library(rvest)

reddit_webpage<-read_html('https://www.reddit.com/r/politics/comments/a1j9xs/partisan_election_officials_are_inherently_unfair/')

reddit_webpage %>%
  #html_node, grab everthing between the tag <title> and </title>
  html_node('title') %>%
  html_text()

reddit_webpage %>%
  #html_nodes, rvest will look for the tag, and grab every thing between 
  #class names ._1qeIAgB0cPwnLhDF9XSiJM
  html_nodes('p._1qeIAgB0cPwnLhDF9XSiJM') %>%
  html_text()

reddit_political_news <- read_html('https://www.reddit.com/r/politics/new/')

time <- reddit_political_news %>%
  html_nodes('a._3jOxDPIQ0KaOWpzvSQo-1s') %>%
  html_text()

time

urls <- reddit_political_news %>%
  html_nodes('a._3jOxDPIQ0KaOWpzvSQo-1s') %>%
  html_attr('href')

urls

#get the data into a neat dataframe, column1 = urls, column2 = time
reddit_news_times <- data.frame(NewsPage = urls, PublishedTime = time)
dim(reddit_news_times)

#filter out the news that were hours ago, only keep those recent
reddit_recent_news <- reddit_news_times[grep('minute|now', reddit_news_times$PublishedTime), ]
dim(reddit_recent_news)

titles <- c()
comments <- c()

#Iterate through each news link, add the headline and corresponding comments into a data frame
for (i in reddit_recent_news$NewsPage){
  reddit_recent_data <- read_html(i)
  data_comments <- reddit_recent_data %>%
    html_nodes('p._1qeIAgB0cPwnLhDF9XSiJM') %>%
    html_text()
  comments <- append(comments, data_comments)
  
  title <- reddit_recent_data %>%
    html_node('title') %>%
    html_text()
  titles <- append(titles, rep(title,length(data_comments)))
}

reddit_hourly_data <- data.frame(Headlines=titles, Comments=comments)
dim(reddit_hourly_data)  
head(reddit_hourly_data, 10)  


disclaimers <- c(
  "As a reminder, this subreddit is for civil discussion.",
  "In general, be courteous to others. Debate/discuss/argue the merits of ideas, don't attack people. Personal insults, shill or troll accusations, hate speech, any advocating or wishing death/physical harm, and other rule violations can result in a permanent ban.",
  "If you see comments in violation of our rules, please report them.",
  "For those who have questions regarding any media outlets being posted on this subreddit, please click here to review our details as to whitelist and outlet criteria.",
  "I am a bot, and this action was performed automatically. Please contact the moderators of this subreddit if you have any questions or concerns."
)

#get rid of the disclaimers which could skew our future analysis
reddit_hourly_data_no_disclaimers <- subset(
  reddit_hourly_data, !(Comments %in% c(disclaimers))
)

dim(reddit_hourly_data_no_disclaimers)
head(reddit_hourly_data_no_disclaimers$Comments)

library(sentimentr)

#convert factor to character
reddit_hourly_data_no_disclaimers$Comments <- as.character(reddit_hourly_data_no_disclaimers$Comments)

#sentiment level sentiment analysis
sentiment_scores <- sentiment(reddit_hourly_data_no_disclaimers$Comments)
#one element may contain several sentences.
head(sentiment_scores) 

#calculate the average sentiment
average_sentiment_score <- sum(sentiment_scores$sentiment)/length(sentiment_scores$sentiment)
average_sentiment_score

# Email the results of the analysis
# install.packages("sendmailR")
library(sendmailR)
from <- "<403403nzf@gmail.com>"
to <- "<403403nzf@gmail.com>"
subject <- "Hourly Sentiment Score on Current US Political Situation"
body <- c("On a scale of 1 to -1 people feel: ", average_sentiment_score)            
mailControl <- list(smtpServer="aspmx.l.google.com") #Use Google for Gmail accounts

sendmail(from=from,to=to,subject=subject,msg=body,control=mailControl)
