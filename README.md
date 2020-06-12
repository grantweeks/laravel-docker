# EMCP Reader v2

## Docker

The `docker-compose.yaml` file in this repo will help you build a Docker-based environment for developing the EMCP Reader v2 project in a standardized and predictable manner across host platforms.

### First-Time Setup

#### 1. Folder Structure
Because this project combines code from four different repositories, it is recommended that you clone this repo into a container folder. After doing this, open a shell, `cd` to this new folder, and run this command:

    git clone ssh://git@bitbucket.blueearth.net:7999/emcp/emcp-reader-docker.git reader-docker

#### 2. Edit your Path Variable
There are several crucial helper scripts in the `reader-docker/bin` folder. You must add `./bin` to the path variable in your `.bash_profile` file in order to use these scripts. Ex: `export PATH=$PATH:./bin`

#### 3. Run the Setup Script

Change your working directory to `reader-docker` and run `setup`. This will only work if you have modified your path as recommended in the first paragraph above!

The `setup` script does the following:

1) Deletes existing networks, containers, and images in the `emcp.reader` namespace.
1) Builds images from dockerfiles.
2) Starts the `db` container and executes all scripts* in the `reader-docker/db-init-d` folder in alphanumerical order.
3) Checks out three repositories into `reader-admin`, and `reader-v2`.
4) Performs setup work (`npm install`, `composer install`, etc.) for the `app` and `node` services.

*The first script (`1-setup.sql`) creates the `ebook_reader` database and sets up the `beidev` user. The last script (`2-shutdown.sh`) stops the container so the remainder of setup can complete. If you want to populate the database, put the database dump into `/db-init/2-insert.sql.gz`.

When `setup` is finished running, you should have a folder structure that looks like this:

    project-folder
    └┬reader-admin
     ├reader-docker
     ├reader-v1
     └reader-v2


#### 4. Edit Your `.env` File

`reader-docker/.env` contains environmental variables used by Docker when parsing the `docker-compose.yaml` file for this projecy.

The following variables need to be put into this file.

* MailTrap username and password

Do not try committing this file; it is in `.gitignore`.

### Running the Service Containers

When you are in the `reader-docker` folder, you can use the `dk` script as a shortcut for `docker-compose`. It saves typing and also sets the `HOST_IP` environmental variable so Xdebug can connect to your host for debugging in your IDE.

To start all service containers and attach their output to your terminal:

    dk up

To start one service container discreetly and attach its output to your terminal:

    dk up node

### The Service Containers

#### The `node` Service

Once booted and running, `emcp.reader.svc.node` service container will automatically execute `ionic serve all --nobrowser --no-interactive --port 80`.

This command builds and serves (with live-reload) the Ionic-based front-end of the site, reachable from your host operating system here: [localhost:8100](http://localhost:8100)

The source code is in the bind-mounted `reader-v2` folder: 

#### The `db` Service

The `emcp.reader.svc.db` service container runs MySQL. This service can take a long time to start for the first time if you have a large database dump file sitting in the `reader-docker/db-init-d` folder.

MySQL’s data files can be found in the bind-mounted `reader-docker/db-data` folder.

#### The `app` Service

The `emcp.reader.svc.app` service container runs PHP-FPM as a FastCGI service on port 9000.

#### The `web` Service

The `emcp.reader.svc.web` service container runs nginx, handling web requests for various sites. They are:

- Reader Admin Site: [emcp-reader-admin.bei](http://emcp-reader-admin.bei) 
- New Reader Site/App: [emcp-reader-v2.bei](http://emcp-reader-v2.bei)

This service binds to port 80 on the host, so you might get an error if another webserver is running on this port.

#### The `mem` Service

The `emcp.reader.svc.mem` service container runs memcached, handling sessions.

### Executing Commands in Service Containers

When a service container is running and you are in the `reader-docker` folder, you can execute commands inside it with `docker-compose exec`. To save typing, use the `dx` shortcut script in the `reader-docker/bin` folder.

    dx SERVICE COMMAND [ARGS]

Examples for the `emcp.reader.svc.node` container:

- Stubbing with Ionic CLI: `dx node ionic generate component foo`
- Bash shell: `dx node bash`
- NPM install: `dx node npm install`
- NPM scripts: `dx node npm run clean`
- Cordova commands: `dx node cordova info`

Examples for other service containers:

- Reload nginx: `dx web nginx -s reload`
- PHP info: `dx app php -i`
- Composer: `dx app composer`
- MySQL shell: `dx db mysql -u root`

### Building for iOS and Android

Use `dx node cordova` when the `emcp.reader.svc.ionic` container is running to add platforms and build for them.

#### Examples
- Add iOS: `dx node cordova platform add ios`
- Build iOS: `dx node cordova platform build ios`
- Add Android: `dx node cordova platform add android`
- Build Android: `dx node cordova platform build android`

### White-Labeling

## Changing Brands
In the `reader-docker` folder, run the `brand` script. Follow the interactive prompt. After choosing a brand, the project’s `ionic.config.json` and `manifest.json` will get updated accordingly. The next time Webpack runs, it will compile for the brand you selected.

## Angular Config
The last identifier of the app’s namespace (ex: `emc` or `paradigm`) combined with the deployment environment (`dev` or `prod`) form the basis for the application’s configuration file in the `reader-v2/src/config/` folder. Examples:

* `emc.dev.ts`
* `emc.prod.ts`
* `paradigm.dev.ts`
* `paradigm.prod.ts`

In your Angular code, the import below will give you a CONFIG constant for the brand you selected.

import { CONFIG } from '@config';

When a new brand is added to the `brand` script, be sure to create the corresponding configuration files for it.

### Rebuilding Things

#### Rebuilding the MySQL Database
Make sure the `db` service is stopped.
Delete everything in the `reader-docker/db-data` folder.
Run `dk up db` to make the `db` service re-run
all scripts in the `reader-docker/db-init-d` folder.
