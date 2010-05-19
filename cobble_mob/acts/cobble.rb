# The **cobble mob** does various tasks to get a fresh slice in a known, useful state.
# In particular, cobbling should leave igor running and ready to take things from there.

# Set defaults
setup_node do |node,defaults|
  # Load the default resource locator.
  require 'common_mob/resource_locator'
  node.resource_locator = CommonMob::ResourceLocator.new

  # Our little home on every slice
  node.root = "/usr/local/plus2".pathname
end

# This meta-act schedules all the other acts.
act 'bootstrap' do
  schedule_act 'configure-ips'

  schedule_act 'install-git'
  schedule_act 'fix-hostname'
  schedule_act 'ping-github'
end

# On Linode we need to configure our own private IPs.
# This is a bit of a pain, but here we use the API to make it bearable.
act 'configure-ips' do
  if node.provider? && node.provider.name == 'linode' && !node.private_ip.blank?
    # Man, we really have to reboot.
    #
    # This means that you have to wait for the reboot, then re-cobble.
    # Hopefully this process is idempotent!
    template("/etc/network/interfaces", :src => 'linode-interfaces.erb').changed? && (
      sh("reboot", :action => :execute) # XXX careful!
      throw :halt
    )

  end
end

# Install all those build tools we need.
act 'install-build-tools' do
  apt 'build-essential'
  apt 'flex'
  apt 'bison'
  apt 'libssl-dev'
  apt 'ca-certificates'
end

# Download and install git from source.
act 'install-git' do
  act_now 'install-build-tools'

  apt 'libcurl4-openssl-dev'

  work_root = "/tmp/bootstrap/git".pathname
  git = "git-1.7.0.1"
  arc = "#{git}.tar.bz2"
  url = "http://kernel.org/pub/software/scm/git/#{arc}"
  sha = "ea8fd7fa7bfac5c64e549e92f431649dbb961ce73e9e45945f7f3c6f176b636368a53d52c8ed1941aa905e1d7ba27505e3367244473173a8182538aa679bf16c"

  dir work_root+'src'

  fetch( work_root+arc, :src => url, :sha512 => sha )
  tarball( work_root+arc, :dest => work_root+'src' )
  sh( "./configure --without-tcltk --without-python && make install", :cwd => work_root+'src', :creates => '/usr/local/bin/git' )
end



# Fix things up so that our hostname is useful for identifying the box to itself :P
act 'fix-hostname' do
  patch("/etc/hosts", :key => 'am-hostname', :string => "127.0.1.1\t#{node.name}")
  file("/etc/hostname", :string => node.name)
  sh "/etc/init.d/hostname.sh start; true"
end





# Register our ssh key with the github user `plus2deployer`. This is so that we can github on plus2's behalf.
act 'ping-github' do
  dot_ssh = "/root/.ssh".pathname.expand_path
  id_dsa = dot_ssh+'id_dsa'
  id_dsa_pub = dot_ssh+'id_dsa.pub'

  # Generate a key.
  sh( "echo | ssh-keygen -t dsa -f #{id_dsa}", :creates => id_dsa, :as => 'root' ).changed? &&
  # Use the github API to register the key.
  sh( "curl -v -F 'login=#{node.github.user}' -F 'token=#{node.github.api_token}' -F 'key=#{id_dsa_pub.read.chomp}' " \
      "'https://github.com/api/v2/json/user/key/add' -H 'Accept: text/json'",
    :as => 'root'
  ).changed? &&
  # ssh to github with `StrictHostKeyChecking no`. This stops us having to manually agreeing to add the key to our known_hosts.
  # This is probably a gaping security hole, mind.
  sh("ssh -o'StrictHostKeyChecking no' git@github.com; exit 0", :as => 'root')
end
