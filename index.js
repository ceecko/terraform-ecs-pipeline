const express = require('express')
const app = express()
const port = process.env.PORT || 3000

const AmazonCognitoIdentity = require('amazon-cognito-identity-js');
const CognitoUserPool = AmazonCognitoIdentity.CognitoUserPool;
const AWS = require('aws-sdk');
const request = require('request');
const jwkToPem = require('jwk-to-pem');
const jwt = require('jsonwebtoken');
global.fetch = require('node-fetch');


const poolData = {    
  UserPoolId : process.env.COGNITO_USER_POOL_ID,
  ClientId : process.env.COGNITO_CLIENT_ID
}; 
const pool_region = 'eu-west-1';
const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);


function login() {
  const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails({
    Username : 'user',
    Password : 'password1',
  });

  const userData = {
    Username : 'user',
    Pool : userPool
  };
  const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function (result) {
      console.log('identity token')
      console.log(result.getIdToken().getJwtToken());
    },
    onFailure: function(err) {
      console.log(err);
    },
    newPasswordRequired: function(userAttributes, requiredAttributes) {
      // User was signed up by an admin and must provide new
      // password and required attributes, if any, to complete
      // authentication.

      // the api doesn't accept this field back
      delete userAttributes.email_verified;

      // store userAttributes on global variable
      sessionUserAttributes = userAttributes;
      console.log(sessionUserAttributes)
      cognitoUser.completeNewPasswordChallenge('password1', sessionUserAttributes)
    }
  });
}


app.get('/', (req, res) => res.send('Hello from ECS!'))
app.get('/login', (req, res) => {
  login()
  res.send('check console for identity token')
})
app.listen(port, () => console.log(`Example app listening on port ${port}!`))