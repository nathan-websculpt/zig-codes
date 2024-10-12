- Works differently from Linux to windows
- I had trouble with this `zig fetch --save https://github.com/Hejsil/zig-clap/archive/refs/tags/<REPLACE ME>.tar.gz`
- This works fine (I must just be running the latest main of zig) `zig fetch --save git+https://github.com/Hejsil/zig-clap`
- Leaving this directory alone as just notes, because reading arguments from the command line ended up being a little bit more difficult than I thought it would be, lol

##### `--` is how you pass arguments to the binary you want to generate (otherwise you are sending them to `build`)

- Running this

```
zig build run -- one -n 42 -s hello --string world two 

```

- Running that ☝️ Ouputs this 👇

```
--number = 42
--string = hello
--string = world
one
two

```