const AWS_EC2_INSTANCE_ID = process.env.AWS_EC2_INSTANCE_ID;
const AWS_REGION = process.env.AWS_REGION;

const PRISM_FORCE_HTTPS = process.env.PRISM_FORCE_HTTPS;


module.exports = {
  apps: [
    {
      name: 'prism',
      script: '/rankscience/prism-stage/lib/index.js',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        AWS_EC2_INSTANCE_ID,
        AWS_REGION,
        PRISM_FORCE_HTTPS,
      },
    },
  ],
};
