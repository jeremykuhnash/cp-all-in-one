#!/bin/bash
# https://docs.confluent.io/platform/current/kafka-rest/quickstart.html#produce-and-consume-json-messages

if [ $# -eq 0 ]; then
    echo "No arguments supplied - please supply the endpoint like http://localhost:8082"
    exit 1  
fi
REMOTE_HOST_URI=$1
#REMOTE_HOST_URI="http://localhost:8082"
#REMOTE_HOST_URI="http://localhost:18082"
#REMOTE_HOST_URI="https://localhost:48082"

echo $REMOTE_HOST_URI

# Produce a message using JSON with the value '{ "foo": "bar" }' to the topic jsontest
for i in {1..5}
do
    echo "Producing message { 'foo': 'bar$i' }"
    curl -k -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" \
        --data '{"records":[{"value":{"foo":"bar'$i'"}}]}' "$REMOTE_HOST_URI/topics/jsontest"
        echo
done 

# Expected output from preceding command
#   {
#    "offsets":[{"partition":0,"offset":0,"error_code":null,"error":null}],"key_schema_id":null,"value_schema_id":null
#   }

# Create a consumer for JSON data, starting at the beginning of the topic's
# log and subscribe to a topic. Then consume some data using the base URL in the first response.
# Finally, close the consumer with a DELETE to make it leave the group and clean up
# its resources.
echo "Setting up consumer my_consumer_instance"
curl -k -X POST -H "Content-Type: application/vnd.kafka.v2+json" \
      --data '{"name": "my_consumer_instance", "format": "json", "auto.offset.reset": "earliest"}' \
      $REMOTE_HOST_URI/consumers/my_json_consumer

# Expected output from preceding command
#  {
#   "instance_id":"my_consumer_instance",
#   "base_uri":"$REMOTE_HOST_URI/consumers/my_json_consumer/instances/my_consumer_instance"
#  }
echo "Setting up Subscription" 
curl -k -X POST -H "Content-Type: application/vnd.kafka.v2+json" --data '{"topics":["jsontest"]}' \
 $REMOTE_HOST_URI/consumers/my_json_consumer/instances/my_consumer_instance/subscription
# No content in response

echo "Getting records..."
curl -k -X GET -H "Accept: application/vnd.kafka.json.v2+json" \
      $REMOTE_HOST_URI/consumers/my_json_consumer/instances/my_consumer_instance/records

# Expected output from preceding command
#   [
#    {"key":null,"value":{"foo":"bar"},"partition":0,"offset":0,"topic":"jsontest"}
#   ]

echo "Closing Consumer"
curl -k -X DELETE -H "Content-Type: application/vnd.kafka.v2+json" \
      $REMOTE_HOST_URI/consumers/my_json_consumer/instances/my_consumer_instance
# No content in response


echo
echo
