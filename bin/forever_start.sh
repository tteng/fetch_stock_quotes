#!/bin/bash
forever start --pidFile $PWD/pids/stock_quote.pid -a -l $PWD/logs/stock_quotes.log $PWD/lib/index.js
echo "done."
