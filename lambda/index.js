const apiAgent = require("./api-agent");

exports.handler = async function (event, context) {
  console.log("ENVIRONMENT VARIABLES\n" + JSON.stringify(process.env, null, 2));

  const apiUrl = `http://${process.env.DOCKER_GATEWAY_HOST || "172.17.0.1"}:${
    process.env.API_PORT || 4000
  }`;
  const apiData = JSON.stringify(event);

  apiAgent(apiData, apiUrl);

  return context.logStreamName;
};
