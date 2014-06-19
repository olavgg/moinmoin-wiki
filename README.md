moinmoin-wiki
=============

Docker image with the Moinmoin wiki engine, uwsgi, nginx and self signed SSL.

You can automatically download and run this with the following command
    
    sudo docker run -it -p 127.0.0.1:443:443 -p 127.0.0.1:80:80 --rm --name my_wiki olavgg/moinmoin-wiki
    
