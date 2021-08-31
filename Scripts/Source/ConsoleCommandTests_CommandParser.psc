scriptName ConsoleCommandTests_CommandParser extends ConsoleCommandsTest
{Tests for the command parser}

function Tests()
    ; No Commands, Just Arguments
    Test("can parse empty example").Fn(EmptyCommandTest())
    Test("can parse one argument").Fn(NoCommand_OneArgument())
    Test("can parse multiple arguments").Fn(NoCommand_MultipleArguments())
    Test("parser ignores extra spaces").Fn(NoCommand_MultipleArguments_ExtraSpaces())
    Test("can parse one double quoted argument").Fn(NoCommand_DoubleQuotes_One())
    Test("can parse a first argument double quoted").Fn(NoCommand_DoubleQuotes_First())
    Test("can parse a last argument double quoted").Fn(NoCommand_DoubleQuotes_Last())
    Test("can parse a middle argument double quoted").Fn(NoCommand_DoubleQuotes_Middle())

    ; Commands
    Test("can parse a single command without arguments").Fn(Command_NoArguments())
    Test("can parse a single command with arguments").Fn(Command_Arguments())

    ; Subcommand
    Test("can parse a single subcommand without arguments").Fn(Subcommand_NoArguments())
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Just text. No Commands.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function EmptyCommandTest()
    int result = ConsoleCommandParser.Parse("")
    
    ExpectBool(ConsoleCommandParser.IsEmpty(result)).To(BeTrue())
    ExpectString(ConsoleCommandParser.GetText(result)).To(BeEmpty())
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(BeEmpty())
endFunction

function NoCommand_OneArgument()
    int result = ConsoleCommandParser.Parse("hello")
    
    ExpectBool(ConsoleCommandParser.IsEmpty(result)).To(BeFalse())
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(1))
    ExpectString(ConsoleCommandParser.GetArguments(result)[0]).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
endFunction

function NoCommand_MultipleArguments()
    int result = ConsoleCommandParser.Parse("hello world")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello world"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(2))
    ExpectString(ConsoleCommandParser.GetArguments(result)[0]).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArguments(result)[1]).To(EqualString("world"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("world"))
endFunction

function NoCommand_MultipleArguments_ExtraSpaces()
    int result = ConsoleCommandParser.Parse(" hello      world   hi    ")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString(" hello      world   hi    "))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(3))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("world"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 2)).To(EqualString("hi"))
endFunction

function NoCommand_DoubleQuotes_One()
    int result = ConsoleCommandParser.Parse("\"hello\"")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To("\"hello\"")
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(1))
    ExpectString(ConsoleCommandParser.GetArguments(result)[0]).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
endFunction

function NoCommand_DoubleQuotes_First()
    int result = ConsoleCommandParser.Parse("\"hello\" world")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("\"hello\" world"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(2))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("world"))
endFunction

function NoCommand_DoubleQuotes_Last()
    int result = ConsoleCommandParser.Parse("hello \"world\"")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello \"world\""))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(2))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("world"))
endFunction

function NoCommand_DoubleQuotes_Middle()
    int result = ConsoleCommandParser.Parse("hello \"world\" hi")
    
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello \"world\" hi"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(3))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("hello"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("world"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 2)).To(EqualString("hi"))
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Command_NoArguments()
    int command = ConsoleCommands.Add("hello")

    int result = ConsoleCommandParser.Parse("hello")

    ExpectBool(ConsoleCommandParser.IsEmpty(result)).To(BeFalse())
    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(BeEmpty())
    ExpectString(ConsoleCommandParser.GetCommand(result)).To(EqualString("hello"))
    ExpectInt(ConsoleCommandParser.IdForCommand(result)).To(EqualInt(command))
endFunction

function Command_Arguments()
    int command = ConsoleCommands.Add("hello")

    int result = ConsoleCommandParser.Parse("hello world hi")

    ExpectString(ConsoleCommandParser.GetText(result)).To(EqualString("hello world hi"))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(HaveLength(2))
    ExpectString(ConsoleCommandParser.GetArgument(result, 0)).To(EqualString("world"))
    ExpectString(ConsoleCommandParser.GetArgument(result, 1)).To(EqualString("hi"))
    ExpectString(ConsoleCommandParser.GetCommand(result)).To(EqualString("hello"))
    ExpectInt(ConsoleCommandParser.IdForCommand(result)).To(EqualInt(command))
endFunction

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;; Subcommands
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Subcommand_NoArguments()
    int command = ConsoleCommands.Add("greeting")
    int subcommand = ConsoleCommands.AddSubcommand("greeting", "hello")

    int result = ConsoleCommandParser.Parse("greeting")
    ExpectInt(ConsoleCommandParser.IdForCommand(result)).To(EqualInt(command))
    ExpectInt(ConsoleCommandParser.IdForCommandOrSubcommand(result)).To(EqualInt(command))
    ExpectInt(ConsoleCommandParser.IdForSubcommand(result)).To(EqualInt(0))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(BeEmpty())

    result = ConsoleCommandParser.Parse("greeting hello")
    ExpectInt(ConsoleCommandParser.IdForCommand(result)).To(EqualInt(command))
    ExpectInt(ConsoleCommandParser.IdForCommandOrSubcommand(result)).To(EqualInt(subcommand))
    ExpectInt(ConsoleCommandParser.IdForSubcommand(result)).To(EqualInt(subcommand))
    ExpectStringArray(ConsoleCommandParser.GetArguments(result)).To(BeEmpty())
endFunction

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;; Flags
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;; Options
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
