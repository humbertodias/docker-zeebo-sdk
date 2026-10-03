# hello

BREW applet that fills the screen black and draws **Hello World from Zeebo** in white, centered.

```bash
make -C examples/hello
```

On a Mac, `make` enters the image and compiles there. Open `hello.mod` in zeebx with the other files in this directory beside it.

## Files

| File | Role |
|---|---|
| `hello.c` | The applet. `AEEClsCreateInstance` creates class `0x0100F001`, draws the text, and arms a one-second timer. Without that timer zeebx ends the session. |
| `hello.bid` | ClassID `AEECLSID_HELLOWORLD` (`0x0100F001`). The `.c` and the `.cif` include this file so the module and the manifest name the same class. |
| `hello.cif` | Manifest source. The `Applet` block says which class to create in `hello.mod`. |
| `Makefile` | On the host, it starts Docker. In the image, it compiles `hello.elf`, then writes `hello.mod` with `elf2mod` and `hello.mif` with `cifc`. |
| `hello.mod` | Module zeebx runs. Output of `make`. |
| `hello.mif` | Manifest next to the module. Output of `make`. Zeebx reads the `Applet` record from here. |
| `hello.elf` | Intermediate ELF. Zeebx does not open it. `make clean` removes it along with `.mod` and `.mif`. |
| `arial.ttf` | Font for the letters. Zeebx uses the `.ttf` in this directory. Without it the screen stays black and the text is not drawn. |

To run: `hello.mod`, `hello.mif`, and `arial.ttf` in the same directory.
