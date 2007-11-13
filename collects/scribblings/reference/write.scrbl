#lang scribble/doc
@require[scribble/bnf]
@require["mz.ss"]

@define[(FmtMark . s) (apply litchar "~" s)]

@title{Writing}

@declare-exporting[(lib "scheme/write")]

@defproc[(write [datum any/c][out output-port? (current-output-port)])
         void?]{

Writes @scheme[datum] to @scheme[out], normally in such a way that
instances of core datatypes can be read back in. If @scheme[out] has a
handler associated to it via @scheme[port-write-handler], then the
handler is called. Otherwise, the default printer is used (in
@scheme[write] mode), as configured by various parameters.

See @secref["printing"] for more information about the default
printer. In particular, note that @scheme[write] may require memory
proportional to the depth of the value being printed, due to the
initial cycle check.}

@defproc[(display [datum any/c][out output-port? (current-output-port)])
         void?]{

Displays @scheme[datum] to @scheme[out], similar to @scheme[write],
but usually in such a way that byte- and character-based datatypes are
written as raw bytes or characters. If @scheme[out] has a handler
associated to it via @scheme[port-display-handler], then the handler
is called. Otherwise, the default printer is used (in @scheme[display]
mode), as configured by various parameters.

See @secref["printing"] for more information about the default
printer. In particular, note that @scheme[display] may require memory
proportional to the depth of the value being printed, due to the
initial cycle check.}

@defproc[(print [datum any/c][out output-port? (current-output-port)])
         void?]{

Writes @scheme[datum] to @scheme[out], normally the same way as
@scheme[write]. If @scheme[out] has a handler associated to it via
@scheme[port-print-handler], then the handler is called. Otherwise,
the handler specified by @scheme[global-port-print-handler] is called;
the default handler uses the default printer in @scheme[write] mode.

The rationale for providing @scheme[print] is that @scheme[display]
and @scheme[write] both have relatively standard output conventions,
and this standardization restricts the ways that an environment can
change the behavior of these procedures. No output conventions should
be assumed for @scheme[print], so that environments are free to modify
the actual output generated by @scheme[print] in any way.}


@defproc[(fprintf [out output-port?][form string?][v any/c] ...) void?]{

Prints formatted output to @scheme[out], where @scheme[form] is a string
that is printed directly, except for special formatting
escapes:

@itemize{

  @item{@FmtMark{n} or @FmtMark{%} prints a newline}

  @item{@FmtMark{a} or @FmtMark{A} @scheme[display]s the next argument
  among the @scheme[v]s}

  @item{@FmtMark{s} or @FmtMark{S} @scheme[write]s the next argument
  among the @scheme[v]s}

  @item{@FmtMark{v} or @FmtMark{V} @scheme[print]s the next argument
  among the @scheme[v]s}
 
  @item{@FmtMark{e} or @FmtMark{E} outputs the next argument among the
  @scheme[v]s using the current error value conversion handler (see
  @scheme[error-value->string-handler]) and current error printing
  width} @item{@FmtMark{c} or @FmtMark{C} @scheme[write-char]s the
  next argument in @scheme[v]s; if the next argument is not a
  character, the @exnraise[exn:fail:contract]}

  @item{@FmtMark{b} or @FmtMark{B} prints the next argument among the
  @scheme[v]s in binary; if the next argument is not an exact number, the
  @exnraise[exn:fail:contract]}

  @item{@FmtMark{o} or @FmtMark{O} prints the next argument among the
  @scheme[v]s in octal; if the next argument is not an exact number, the
  @exnraise[exn:fail:contract]}

  @item{@FmtMark{x} or @FmtMark{X} prints the next argument among the
  @scheme[v]s in hexadecimal; if the next argument is not an exact
  number, the @exnraise[exn:fail:contract]}

  @item{@FmtMark{~} prints a tilde.}

  @item{@FmtMark{}@nonterm{w}, where @nonterm{w} is a whitespace character,
  skips characters in @scheme[form] until a non-whitespace
  character is encountered or until a second end-of-line is
  encountered (whichever happens first). An end-of-line is either
  @scheme[#\return], @scheme[#\newline], or @scheme[#\return] followed
  immediately by @scheme[#\newline] (on all platforms).}

}

The @scheme[form] string must not contain any @litchar{~} that is
not one of the above escapes, otherwise the
@exnraise[exn:fail:contract]. When the format string requires more
@scheme[v]s than are supplied, the
@exnraise[exn:fail:contract]. Similarly, when more @scheme[v]s are
supplied than are used by the format string, the
@exnraise[exn:fail:contract].

@examples[
(fprintf (current-output-port)
         "~a as a string is ~s.~n"
         '(3 4) 
         "(3 4)")
]}

@defproc[(printf [form string?][v any/c] ...) void?]{
The same as @scheme[(fprintf (current-output-port) form v ...)].}

@defproc[(format [form string?][v any/c] ...) string?]{
Formats to a string. The result is the same as

@schemeblock[
(let ([o (open-output-string)])
  (fprintf o form v ...)
  (get-output-string o))
]

@examples[
(format "~a as a string is ~s.~n" '(3 4) "(3 4)")
]}

@defboolparam[print-pair-curly-braces on?]{

A parameter that control pair printing. If the value is true, then
pairs print using @litchar["{"] and @litchar["}"] instead of
@litchar["("] and @litchar[")"]. The default is @scheme[#f].}


@defboolparam[print-mpair-curly-braces on?]{

A parameter that control pair printing. If the value is true, then
mutable pairs print using @litchar["{"] and @litchar["}"] instead of
@litchar["("] and @litchar[")"]. The default is @scheme[#t].}

@defboolparam[print-unreadable on?]{

A parameter that controls printing values that have no
@scheme[read]able form (using the default reader), including
structures that have a custom-write procedure (see
@scheme[prop:custom-write]); defaults to @scheme[#t]. See
@secref["printing"] for more information.}

@defboolparam[print-graph on?]{

A parameter that controls printing data with sharing; defaults to
@scheme[#f]. See @secref["printing"] for more information.}

@defboolparam[print-struct on?]{

A parameter that controls printing structure values in vector form;
defaults to @scheme[#t]. See @secref["printing"] for more
information. This parameter has no effect on the printing of
structures that have a custom-write procedure (see
@scheme[prop:custom-write]).}

@defboolparam[print-box on?]{

A parameter that controls printing box values; defaults to
@scheme[#t]. See @secref["print-box"] for more information.}

@defboolparam[print-vector-length on?]{

A parameter that controls printing vectors; defaults to
@scheme[#t]. See @secref["print-vectors"] for more information.}

@defboolparam[print-hash-table on?]{

A parameter that controls printing hash tables; defaults to
@scheme[#f]. See @secref["print-hashtable"] for more information.}

@defboolparam[print-honu on?]{

A parameter that controls printing values in an alternate syntax.  See
@secref["honu"] for more information.}


@defproc*[([(port-write-handler [out output-port?]) (any/c output-port? . -> . any)]
           [(port-write-handler [in input-port?]
                                [proc (any/c output-port? . -> . any)])
            void?])]{}

@defproc*[([(port-display-handler [out output-port?]) (any/c output-port? . -> . any)]
           [(port-display-handler [in input-port?]
                                 [proc (any/c output-port? . -> . any)])
            void?])]{}

@defproc*[([(port-print-handler [out output-port?]) (any/c output-port? . -> . any)]
           [(port-print-handler [in input-port?]
                                [proc (any/c output-port? . -> . any)])
            void?])]{

Gets or sets the @deftech{port write handler}, @deftech{port display
handler}, or @deftech{port print handler} for @scheme[out]. This
handler is call to output to the port when @scheme[write],
@scheme[display], or @scheme[print] (respectively) is applied to the
port.  Each handler takes a two arguments: the value to be printed and
the destination port. The handler's return value is ignored.

The default port display and write handlers print Scheme expressions
with Scheme's built-in printer (see @secref["printing"]). The
default print handler calls the global port print handler (the value
of the @scheme[global-port-print-handler] parameter); the default
global port print handler is the same as the default write handler.}

@defparam[global-port-print-handler proc (any/c output-port? . -> . any)]{

A parameter that determines @deftech{global port print handler},
which is called by the default port print handler (see
@scheme[port-print-handler]) to @scheme[print] values into a port.
The default value uses the built-in printer (see
@secref["printing"]) in @scheme[write] mode.}

