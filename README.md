# Erlang-Reminders
A simple concurrent Erlang exercise based on the example given in Chapter 12 of "Learn You Some Earlang For Great Good" by Fred Hebert

## Use
A simple execution example of this application is as follows:

```
evserv:start().
evserv:subscribe(self()).

# The final argument is the date and time that you wish the event to complete
evserv:add_event("<Whatever event title you desire>", "<A description of the event>", {{YYYY,MM,DD},{HH,MM,SS}}).
evserv:listen(<the number of seconds you would like to pause and wait for event response>).
```

A basic supervisor is also built into this example.

```
SupPid = sup:start(evserv,[]). # Start the supervisor and event server
exit(whereis(evserv),die). # Kill the event server to test the supervisor
exit(whereis(sup),die). # Kill the supervisor and notice that all children are also killed
```

## Source
http://learnyousomeerlang.com/designing-a-concurrent-application