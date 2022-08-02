my constant PRINTABLE_TABLE = do {
    my int @table;
    @table[flat ords("\t\b\o33\o14"), 32..126, 128..255] = 1 xx *;
    @table
}

my uint $ten      = 10;
my uint $thirteen = 13;

proto is-text(|) is export {*}
multi is-text(Blob:D $content, Int(Cool) :$test-bytes = 4096) {
    my int $limit = $content.elems min $test-bytes;
    my int $printable;
    my int $unprintable;
    for ^$limit -> int $i is copy {
        my uint $check = $content[$i];
        $check
          ?? $check == $thirteen
            ?? $content[++$i] != $ten # \r not followed by \n hints binary
              ?? (return False)
              !! Nil
            !! $check == $ten         # Ignore lone \n
              ?? Nil
              !! PRINTABLE_TABLE[$check]
                ?? ++$printable
                !! ++$unprintable
          !! (return False)           # NULL byte, so binary.
    }
    ($printable +> 7) >= $unprintable
}

multi is-text(IO::Path:D $path, Int(Cool) :$test-bytes = 4096) {
    my $fh := $path.open(:r, :bin);
    LEAVE $fh.close;
    is-text($fh.read($test-bytes), :$test-bytes)
}
