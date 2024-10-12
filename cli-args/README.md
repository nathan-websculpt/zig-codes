##### Learning zig-clap for command line args

- cd into dir
- zig init
- ran `zig fetch --save git+https://github.com/Hejsil/zig-clap`

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
