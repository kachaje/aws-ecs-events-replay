#!/usr/bin/env node

const axios = require("axios");

const apiAgent = (data, url) => {
  const method = "post";
  const headers = { "Content-Type": "application/json" };

  axios({ url, data, method, headers })
    .then((res) => {
      console.log(`statusCode: ${res.status}`);
      console.log(res.data);
    })
    .catch((error) => {
      console.error(error);
    });
};

if (process.env.API_DATA && process.env.API_URL) {
  try {
    apiAgent(process.env.API_DATA, process.env.API_URL);
  } catch (e) {
    console.log(e);
  }
}

module.exports = apiAgent;
