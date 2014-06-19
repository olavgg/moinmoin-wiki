moinmoin-wiki
=============

Docker image with the Moinmoin wiki engine, uwsgi, nginx and self signed SSL.

You can automatically download and run this with the following command
    
    sudo docker run -it -p 443:443 -p 80:80 --rm --name my_wiki olavgg/moinmoin-wiki
    
Default superuser is `mmAdmin`, you activate him by creating a new user named `mmAdmin` and set your prefered password.
The pages are mounted as volume, so you can take backup of the system from the host.

You can detach from the container session with `CTRL-Q+P` and then `CTRL-C`
