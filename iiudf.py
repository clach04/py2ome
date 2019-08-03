from pyome import ome_function_instance, VARCHAR, INTEGER, FLOAT
import urllib
import base64
import math

@ome_function_instance(ret=VARCHAR(100), params=[VARCHAR])
def eval(arg):
    return str(eval(arg))

@ome_function_instance(ret=VARCHAR(2048), params=[VARCHAR])
def urlopen(arg):
    return urllib.urlopen(arg).read()

@ome_function_instance(ret=VARCHAR(256), params=[VARCHAR])
@ome_function_instance(ret=VARCHAR(256), params=[VARCHAR, VARCHAR])
def b64encode(s, altchars='+/'):
    return base64.b64encode(s, altchars)

@ome_function_instance(ret=VARCHAR(256), params=[VARCHAR])
@ome_function_instance(ret=VARCHAR(256), params=[VARCHAR, VARCHAR])
def b64decode(s, altchars='+/'):
    return base64.b64decode(s, altchars)

@ome_function_instance(ret=INTEGER, params=[VARCHAR])
def dehex(hex):
    return int(hex, 16)

def factorial(x):
    return (1 if x==0 else x * factorial(x-1))

@ome_function_instance(ret=FLOAT, params=[FLOAT, FLOAT])
def poisson(avg_per_incedent_dot_incedent, expected_events):
    return ((avg_per_incedent_dot_incedent**expected_events)*
                        math.exp(-avg_per_incedent_dot_incedent)) / factorial(
                                                              expected_events)

MAN_ATTACKED_BY_PYTHON = """\
                                                          '.****,.
                                                         *xxOBWBOx*'
                                                      'oOBOxOOOBWWWWO.
                                                ''''',xOxOOOOBW######WO*
                                               'oxxOxxxOxOOOB##########W*
                                               'OOxoxxxxxOOBW###########WO'
                        .*,                   .oOxooxxxxxOBW##############W*
                ,oxooOBBBO*,*                 *BOoooxxxxxOBW###############W
               OWBBWWWWWBOOBB.'               .OxoooxxxxxxxOBWWWW##########O
             .*BBW#WWWWWxxBWWWBBO*           'oOooooxxxxxOOOBBOOB##########O
            ,xOWWWW##WBOxBBBBWWBBBx'        ,oxxoooxxxxxxBWWWW#############*
           .OOOBBBOOxoooOx**oooooxWB*      oOOxxoxxxxxxxOOOB#############O
          .xBOBOOOOxxxxo.         oBBo     oxxxxxxxxxxxOOxOW############O
         .oOOBWOOOOOo*.            .BWO,   ,OOOOxOxxxxxxOB#############W
       ',xxOBBOOOo.                 'xWWO. 'oOOOOxxxxOOOBW############O
      '.oxxBBOxo,                     oBOOOOOOxxxxxxxOOOOBWW########B.
     '.*xxxBBOx*                      *OBBOxxxxxxxxxxOOOxOOBWWW###B*
     .*xxxxOOOo              ''   .*oOBBOOOOOOBBBBBWWWWWWWWBBBB#*
    ,oOOOOOOOx*         .,*****.'*xOOBOooxBWWBBBBBWWW######WBBWWWx
   ,oxxOOOOOOx*       ',********oOOOBO**xWWBBOOOxooooooOB###BBWWB,
  .*oxxxOOOOxo.     '*************BOo*oBWWBxoo*,.........*OWWBWx.
  .oooxOOOOBOx,,,,,******************oWBOx*,,,............,oBWo
  .oxxOOOOOBOooxxOOOOo*************oOBOo,,,.............'..,**
 .,ooxOOOOBOxxxOOOOBBx**,,.....,**xOOo*,,,............'''.,,,,
',***xOOBBBBBBBWWWWWWB*'      '.,oo*,...,,,,.......''.''...,,*,
 .**oooBBWWWWWWBBBBWBo'      '''.,,.,,...**,..,....'''..'..,,,.
  .*o*oxxxxOOOOOOOOBBo.'       ''.,,,,,.***.,...'.'''.''..,,,.*.
   '.*ooo***oo*OBWWWBo,.      '''.,*,*.,**,....'''''...'..,,,.*.
     .***ooo**oBWWWBo,..'''...''...,,,,*o,,...'''''''....,,,..,.
         .o**oOWWWB.'.,*..,.''.......,***,...''''''''..'.,,,....
         ,oooOOWWO. .***.' '....''.'.,**,...''''''''..'.,,,...,.
         ,oxxOBWO. ',,,,,' '..'''.'.,,**,...'' ''''......,...,,,'
        .ooxOOBo   '.,,*,.''..''' ''''..,...'''' ''...'.,....,,,'
        ,oOOOWO     '..*.'''..'.' '''' '.....'' ' '....,,....,,,'
        ,oOOOo'    '' .*,'''..'''''''''..'..' '' '.....,,..,,,**'
        *oOO*      ' '.*,.''..' '''' '..   ..' '''...,,,.....,,'
        *xO*      '  .,**.'''' '''.'''..  ' ..' '....,,.....,,
       .**.          .,**.. '..'''' '..' '  '''''...,........
       .o*          ..,,,......'.''''..' '' '.''...,,.......
      '**          ''.,,..,,*,...'''..''''''............,'
      ,,           '..,....**,..'''.''''''''..........,,'
     '*            ........*oo,.'.....'''''.........,*,
     *.           '..'.....*ooo,...'''.'''........,**,
    '.           ''''''....,*oxo,...........,...,*oo,
    *        ''....'''''....*ooo*.,,*********ooooo*'
"""

@ome_function_instance(ret=VARCHAR(len(MAN_ATTACKED_BY_PYTHON)))
def python():
    return MAN_ATTACKED_BY_PYTHON
