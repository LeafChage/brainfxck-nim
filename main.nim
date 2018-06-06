import strutils, pegs, unicode, tables, os

type
  Token = enum
    Pinc, Pdec, Inc, Dec, Write, Read, Start, End

const
  tokenDic: Table[Token, string] = {
    Pinc: ">",
    Pdec: "<",
    Inc: "+",
    Dec: "-",
    Write: ".",
    Read: ",",
    Start: "[",
    End: "]"
  }.toTable


proc addSpace(src: string): string =
  result = src
  for _, v in tokenDic:
    result = result.replace(v, " " & v)

proc parse(strs: seq[string]): seq[Token] =
  var tokens = newSeq[Token](1)
  for t in strs:
    case t
    of tokenDic[Pinc]:  tokens.add(Pinc)
    of tokenDic[Pdec]:  tokens.add(Pdec)
    of tokenDic[Inc]:   tokens.add(Inc)
    of tokenDic[Dec]:   tokens.add(Dec)
    of tokenDic[Write]: tokens.add(Write)
    of tokenDic[Read]:  tokens.add(Read)
    of tokenDic[Start]: tokens.add(Start)
    of tokenDic[End]:   tokens.add(End)
  result = tokens

proc run(tokens: seq[Token]) =
  var
    memory = newSeq[uint](10000)
    memoryPointer = 0
    jumpPoint = 0
    i = 0

  while i < tokens.len:
    case tokens[i]
    of Pinc:
      memoryPointer += 1
      if memoryPointer >= memory.len - 1: memory.add(0)
    of Pdec: memoryPointer -= 1
    of Inc: memory[memoryPointer] += 1
    of Dec: memory[memoryPointer] -= 1
    of Write: write(stdout, memory[memoryPointer].char)
    of Read: echo "read"
    of Start:
      if memory[memoryPointer] == 0:
        while tokens[i] != End: i += 1
      else:
        jumpPoint = i
    of End:
      i = jumpPoint - 1

    i += 1


proc main(path: string) =
  if not os.existsFile(path):
    echo "file not exist"
    return
  var f = open(path, FileMode.fmRead)
  defer: close(f)
  let src = f.readAll()
  src.addSpace.split.parse.run

if isMainModule:
  if paramCount() == 1:
    main($os.commandLineParams()[0])
  else:
    echo "please filepath"

