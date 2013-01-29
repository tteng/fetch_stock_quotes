#!/bin/bash
forever stop --pidFile $PWD/pids/stock_quote.pid $PWD/lib/index.js
echo  "stopped."
