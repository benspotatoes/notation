working_directory '/var/www/notation'

pid '/var/www/pids/unicorn.pid'

stderr_path '/var/www/logs/unicorn_err.log'
stdout_path '/var/www/logs/unicorn_out.log'

listen '/tmp/unicorn.notation.sock'

worker_processes 2

timeout 30
