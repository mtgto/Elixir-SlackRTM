Elixir-SlackRtm
========

An Slack RealTimeMessage (RTM) API client written in Elixir.

# Usage
```
state = SlackRtm.open!("### YOUR Slack API Token ###")
# recv
spawn fn -> SlackRtm.loop(state) end
# send a message to channel "C12345678" (example)
SlackRtm.send!(state, "hello!", "C12345678")
```

# License
The MIT License. See LICENSE for details.
