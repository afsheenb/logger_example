const AWS_EC2_INSTANCE_ID = process.env.AWS_EC2_INSTANCE_ID;
const AWS_REGION = process.env.AWS_REGION;
const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID;
const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY;
const GALILEO_TRANSFORMS_PATH = process.env.GALILEO_TRANSFORMS_PATH;

const PRISM_FORCE_HTTPS = process.env.PRISM_FORCE_HTTPS;


module.exports = {
  apps: [
    {
      name: 'galileo-stage',
      script: '/rankscience/galileo-stage/lib/index.js',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        AWS_EC2_INSTANCE_ID,
        AWS_REGION,
        PRISM_FORCE_HTTPS,
	AWS_ACCESS_KEY_ID,
	AWS_SECRET_ACCESS_KEY,
	GALILEO_TRANSFORMS_PATH,
      },
    },
  ],
};
