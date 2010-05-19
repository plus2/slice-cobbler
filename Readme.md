# Slice Cobbler

Cobble together your slice, using AngryMob.

## Config

Copy `config.eg.json` to `config.json` and customise. Also customise `cobble_mob/acts/cobble.rb`.

## bundler

    $ bundle install


## linode

* upload cobble.sh as a stackscript. If you opt not to, use the `--ruby` flag with `./cobbler`
* create your linode
* add the linode to `config.json` under `servers`

### ssh key

    $ ./cobbler ssh_key my_slice
    # enter password probably, then test it worked:
    $ ./cobbler ssh_to my_slice

### bootstrap

    ./cobbler bootstrap my_slice
    # if you've added a private ip, wait for reboot and cobble again:
    ./cobbler bootstrap my_slice


## not linode

### ssh key

    $ ./cobbler ssh_key my_slice
    # enter password probably, then test it worked:
    $ ./cobbler ssh_to my_slice

### bootstrap

    $ ./cobbler bootstrap my_slice --ruby


## Next steps

I need to add more here, but also fix up cobbler to work.

* create your own mob
* use cobbler to run your mob!

