<!DOCTYPE html>
<html>
  <head>
    <title>Websocket MQTT Client</title>
    <link type="text/css" rel="stylesheet" href="./bower_components/bootstrap/dist/css/bootstrap.min.css"/>
    <script type="text/javascript" src="node_modules/dygraphs/dist/dygraph.js"></script>
    <link rel="stylesheet" src="node_modules/dygraphs/dist/dygraph.css" />
  </head>
  <body>
    <div class="container" ng-app="awsiot.sample" ng-controller="AppController as vm">
      <h1>MQTT Client</h1>
      <div class="jumbotron">
        <p>Find your custom endpoint in the <a href="https://console.aws.amazon.com/iot/home?region=us-east-1#/dashboard/help" target="_blank">iot console</a> or run the command <kbd>aws iot describe-endpoint</kbd>. The IAM credentials(the access key and secret key below) must associate with a policy that has access rights to IoT services(action: <kbd>iot:*</kbd>, resource: <kbd>*</kbd>).
      </p>
    </div>
    <div class="row">
      <div class="col-md-6">
        <div class="form-group">
          <label for="endpoint">Endpoint: </label>
          <input type="text" class="form-control" id="endpoint" placeholder="EndPoint" ng-model="vm.endpoint">
        </div>
        <div class="form-group">
          <label for="regionInput">Region: </label>
          <input type="text" class="form-control" id="regionInput" placeholder="region" ng-model="vm.regionName">
        </div>
      </div>
      <div class="col-md-6">
        <div class="input-group">
          <label for="clientId">Client id: </label>
          <input type="text" class="form-control" id="clientId" ng-model="vm.clientId" />
        </div>
        <div class="input-group">
          <label for="accessKey">Access key: </label>
          <input type="text" class="form-control" id="accessKey" placeholder="AWS access key" ng-model="vm.accessKey"/>
        </div>
        <div class="form-group">
          <label for="secretKey">Secret Key: </label>
          <input type="password" class="form-control" id="secretKey" placeholder="AWS secret key" ng-model="vm.secretKey">
        </div>
      </div>
    </div>
    <div class="row">
      <div class="form-group">
        <button class="btn btn-primary" ng-click="vm.createClient()" ng-disabled="!vm.accessKey || !vm.secretKey">Create Client</button>
      </div>
    </div>
    <div class="panel panel-info" ng-repeat="clientCtr in vm.clients.val">
      <div class="panel-heading">
        <button type="button" class="close"  ng-click="vm.removeClient(clientCtr)"><span>&times;</span></button>
        <h3 class="panel-title">Client {{::clientCtr.client.name}}</h3>
      </div>
      <div class="panel-body row">
        <div class="col-md-6">
          <p>Subscribe to see the messages published to the topic on the left.</p>
          <div class="form-inline">
            <div class="form-group">
              <label for="topicInput">Topic: </label>
              <input type="text" class="form-control" id="topicInput" placeholder="Topic" ng-model="clientCtr.topicName" />
            </div>
            <button class="btn btn-primary" ng-click="clientCtr.subscribe()">Subscribe</button>
          </div>
          <div>
            <p>Press enter in the text box to send message to topic : {{clientCtr.topicName}} </p>
            <textarea id="messageInput" ng-disabled="!clientCtr.topicName" ng-model="clientCtr.message" placeholder="message to send" ng-keyup="clientCtr.msgInputKeyUp($event)"></textarea>
          </div>
        </div>
        <div class="col-md-6">
          <div class="panel panel-info" ng-repeat="msg in clientCtr.msgs">
            <div class="panel-heading">
              <h3 class="panel-title">{{msg.destination}} -> {{msg.receivedTime | date: 'medium'}}</h3>
            </div>
            <div class="panel-body"> {{msg.content}} </div>
          </div>
        </div>
      </div>
    </div>
    <div class="row">
      <h3>Logs:</h3>
      <ul class="list-group">
        <li ng-repeat="log in vm.logs.logs | orderBy:'createdTime':true" class="list-group-item" ng-class="log.className">
          {{log.createdTime | date: 'medium'}} - {{log.content}}
        </li>
      </ul>
    </div>
     
    <div id="graphdiv"></div>
  </div>
</body>
<script type="text/javascript" src="./bower_components/moment/min/moment.min.js"></script>
<script type="text/javascript" src="./bower_components/angular/angular.min.js"></script>
<script type="text/javascript" src="./bower_components/paho-mqtt-js/mqttws31.js"></script>
<script type="text/javascript" src="./bower_components/cryptojslib/rollups/sha256.js"></script>
<script type="text/javascript" src="./bower_components/cryptojslib/rollups/hmac-sha256.js"></script>
<script type="text/javascript" src="./js/app.js"></script>
<script type="text/javascript"> 
g = new Dygraph(

    // containing div
    document.getElementById("graphdiv"),

    // CSV or path to a CSV file.
    './data.txt'

  );
</script> 
</html>