# moinmoin-wiki
=============

Docker image with the Moinmoin wiki engine, uwsgi, nginx and self signed SSL.
Everything included with minimum fuzz and just works.

You can automatically download and run this with the following command
    
    sudo docker run -d -p 443:443 -p 80:80 --name my_wiki olavgg/moinmoin-wiki
    
Default superuser is `mmAdmin`, you activate him by creating a new user named `mmAdmin` and set your prefered password.

Volumes are also supported if you want to simplify backup with rsync or ZFS snapshots

    sudo docker run -d -p 443:443 -p 80:80 -v /opt/moinmoin-data:/usr/local/share/moin/data --name my_wiki olavgg/moinmoin-wiki

## NOTE
Since MoinMoin version 1.9.10 the default security settings became more strict. This Docker release has a much more relaxed security default. [Please read the changes](https://github.com/moinwiki/moin-1.9/blob/1.9.10/docs/CHANGES#L13)

## MoinMoin configuration
MoinMoin has many different configuration options, you can configure this by forking this project, edit the wikiconfig.py file and rebuild the docker image.

### Disable HTTPS / SSL
If you do not need HTTPS you can disable it by passing the -e NOSSL environment variable

    sudo docker run -d -p 80:80 -e NOSSL --name my_wiki olavgg/moinmoin-wiki

Pull requests are very welcome.

