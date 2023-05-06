FROM busybox

CMD ash -c "echo 'Started...'; while true; do sleep 10; done"

# docker build -f hue-learn.Dockerfile -t hue-learn:v3.0 . 
