'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.use(express.json())

app.get('/', (req, res) => {
  res.status(200).send("Thank you for visiting, try posting build information to /builds.");
});

app.post('/builds', (req, res) => {

  let build_date = 0;
  let ami = "";
  let hash = "";

  let builds = req.body.jobs["Build base AMI"].Builds;

  for (const buildindex in builds) {
    let build = builds[buildindex];
    console.log(build);
    if (build["build_date"] > build_date) {
      build_date = build["build_date"];
      if ('output' in build) {
        const output = build["output"].split(" ");
        ami = output[2];
        hash = output[3];
      } else {
        ami = "unknown"
        hash = "unknown"
      }
    }
  }


  // const { jobs } = req.body;
  //res.send(req.body.jobs["Build base AMI"].Builds);

  res.send({
    "latest": {
        "build_date": build_date,
        "ami_id": ami,
        "commit_hash": hash
    }
  })
  // if (!jobs) {
  //   res.status(418).send({ message: 'Process requires a list of jobs.' })
  // }

  // res.status(200).send({
  //   job: `You know it`,
  // })

});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);