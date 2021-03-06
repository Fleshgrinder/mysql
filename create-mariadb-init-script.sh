#!/bin/sh

# ------------------------------------------------------------------------------
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# this software, either in source code form or as a compiled binary, for any
# purpose, commercial or non-commercial, and by any means.
#
# In jurisdictions that recognize copyright laws, the author or authors of this
# software dedicate any and all copyright interest in the software to the
# public domain. We make this dedication for the benefit of the public at large
# and to the detriment of our heirs and successors. We intend this dedication
# to be an overt act of relinquishment in perpetuity of all present and future
# rights to this software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Create new init script for MariaDB after hugepages have been activated.
#
# This init script raises the limit for shared memory to unlimited. Otherwise
# the MariaDB process is not able to lock the hugepages for itself. After
# raising the limit the normal init script is called. We create a separate init
# script to not break the normal apt / aptitude upgrade process of MariaDB
# (which includes the normal mysql init script)!
#
# AUTHOR:    Richard Fussenegger <richard@fussenegger.info>
# COPYRIGHT: 2015 Richard Fussenegger
# LICENSE:   http://unlicense.org/ PD
# ------------------------------------------------------------------------------

# Tell the user that we are goin to create a new init script
printf -- 'Creating new MariaDB inti script at /etc/init.d/mariadb'

# Create the actual init script
cat > /etc/init.d/mariadb << EOT
#!/bin/sh

### BEGIN INIT INFO
# Provides:          MariaDB
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Should-Start:      $network $named $time
# Should-Stop:       $network $named $time
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop the MariaDB database server daemon
# Description:       Controls the main MariaDB database server daemon "mysqld"
#                    and its wrapper script "mysqld_safe".
### END INIT INFO

ulimit -l unlimited
sh /etc/init.d/mysql "${1:-'\'''\''}"

EOT

# Change permissions so it is executable
chmod -- 755 /etc/init.d/mariadb

# Remove the old init script from the system startup
update-rc.d -f mysql remove

# Add our new init script to the system startup
update-rc.d mariadb defaults

# Tell the user that we are done
printf -- '[ok] New init script created and added to system startup.'
