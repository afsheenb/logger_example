const AWS_EC2_INSTANCE_ID = process.env.AWS_EC2_INSTANCE_ID;
const AWS_REGION = process.env.AWS_REGION;

const LENS_FORCE_HTTPS = process.env.LENS_FORCE_HTTPS;


module.exports = {
  apps: [
    {
      name: 'lens',
      script: '/rankscience/prism-dev/lib/index.js',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        AWS_EC2_INSTANCE_ID,
        AWS_REGION,
        LENS_FORCE_HTTPS,
      },
    },
  ],
};
