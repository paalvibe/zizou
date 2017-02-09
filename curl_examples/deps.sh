slack_webhook_token=$SCH_ZIZOU_SLACK_WEBHOOK_TOKEN
response=$(curl -X POST https://sch-zizou.herokuapp.com/bot \
    -H "Accept: application/json" \
    -H "Content-Type: multipart/form-data" \
    -F "trigger_word=fifa" \
    -F "text=fifa departments" \
    -F "token=$slack_webhook_token"
)
echo "response: $response"