moinmoin-wiki
=============

Docker image with the Moinmoin wiki engine, uwsgi, nginx and self signed SSL.
Everything included with minumum fuzz and just works.

You can automatically download and run this with the following command
    
    sudo docker run -d -p 443:443 -p 80:80 --name my_wiki olavgg/moinmoin-wiki
    
Default superuser is `mmAdmin`, you activate him by creating a new user named `mmAdmin` and set your prefered password.
The pages are mounted as volume, so you can take backup of the system from the host.

Volumes are also supported if you want to simplify backup with rsync or ZFS snapshots

    sudo docker run -d -p 443:443 -p 80:80 -v /opt/moinmoin-data:/usr/local/share/moin/data --name my_wiki olavgg/moinmoin-wiki

Pull requests are very welcome.

