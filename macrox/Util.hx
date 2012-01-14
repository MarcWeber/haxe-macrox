package macrox;

import haxe.macro.Context;
import haxe.macro.Expr;
using Type;
using Std;
using Reflect;

// this may be split into pieces later
class Util {
  static public function mapFields<T>(o:Dynamic, fun: String -> Dynamic -> T):Array<T>{
    var r = [];
    // trace(o.fields());
    for (f in o.fields()){
      if (f == "null"){
        // trace(f);
      }
      if (f == null){
        trace("type");
        // trace(o.type);
        // trace("name");
        // trace(o.name);
      }
      r.push(fun(f, o.field(f)));
    }
    return r;
  }

  // if e is a enum and was contstructed by constructor given by name return it else null
  static public function as_con(e:Dynamic, con: String):Null<Dynamic>{
    return null;
  }

  // returns the param_nr's constructor value of the enum
  static public function param_nr(e:Dynamic, param_nr: Int):Null<Dynamic>{
    return null;
  }

  static public function ast_value(e:Dynamic, selector:Array<Dynamic>): Null<Dynamic>{
    for (x in selector){
        if (x.is(String)) {

          // make e null if its not an enum of expected name constructor
          switch (e.typeof()){
            case TEnum(ee):
              var name = ee.getEnumConstructs()[e.enumIndex()];
            default:
              return null;
          }

      } else if (x.is(Int)) {


          // follow n'th constructor field
          switch (e.typeof()){
            case TEnum(ee):
              var tenum_name = ee.getEnumName();
              var ep = e.enumParameters();
              var name = ee.getEnumConstructs()[e.enumIndex()];
              e = e.enumParameters()[x];
            default:
              return null;
          }

      } else throw "unexpected "+x;
    }
    return e;
  }

    // copied from tinkerbell {{{3

    static inline function isUC(s:String) {
      return StringTools.fastCodeAt(s, 0) < 0x5B;
    }

    static public inline function at(e:ExprDef, ?pos:Position) {
      return {
          expr: e,
          pos: pos == null ? Context.currentPos() : pos
      };
    }
    ///builds an expression from an identifier path
    static public function drill(parts:Array<String>, ?pos) {
      var first = parts.shift();
      var ret = at(EConst(isUC(first) ? CType(first) : CIdent(first)), pos);
      for (part in parts)
        ret = 
          if (isUC(part)) 
            at(EType(ret, part), pos);
          else 
            at(EField(ret, part), pos);
      return ret;		
    }
    ///resolves a `.`-separated path of identifiers
    static public inline function resolve_identifier(s:String, ?pos) {
      return drill(s.split('.'), pos);
    }
    // }}}

  static public function d(){
    // this function is not called anywhere. The parser seeing EFunction and
    // EVars is enough to make it work!
    var foo = "8";
    // using untyped because .at can't be used this way. Itz still enough to make the error go away.
//     var r_dummy = untyped EFunction(null,{ ret: null, args : [], expr : EBlock([EReturn( EConst(CInt("7")).at()).at()]).at() , params : [] }).at();
//     var r_dummy2 = untyped EVars([{ expr : EConst(CInt("8")).at(), name : foo, type : null }]);
  }




}
