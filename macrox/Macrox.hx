package macrox;
import Type;
using Reflect;
using Type;
using Std;
using macrox.Util;
import haxe.macro.Context;
import haxe.macro.Expr;

// this may be split into pieces later
class Macrox {


  // HELPER FUNCTIONS {{{2

    @:macro static public function trace(e:Expr){
      trace(e);
      return null;
    }
    /// why oh why do I have to write this !?? ?

    static public function map_a<A,B>(a:Array<A>, f:A -> B):Array<B>{
      var r = new Array();
      for (x in a)
        r.push(f(x));
      return r;
    }

  // }}}



  // return ast which when evaluated returns the same ast.
  // implementation looked up at tinkerbell and changed slightly
  // YES: this should behave like Context.makeExpr, but should be complete
  static public function expr_to_ast_creating_expr(path:Array<Dynamic>, ?patchFun:Array<Dynamic> -> Int -> Null<Dynamic>):Dynamic{
    var l = path.length;

    if (patchFun != null){
      var p_2 = patchFun(path, l);
      if (p_2 != null) return p_2;
    }

    var e:Dynamic = path[l-1];

    // try getting rid of these two:
    var p = haxe.macro.Context.currentPos();
    var with_p : ExprDef -> Expr = function(e){return {pos: p, expr: e};};
    var ast_curr_pos = with_p(ECall(with_p(EField(with_p(EType(with_p(EField(with_p(EConst(CIdent("haxe"))),"macro")),"Context")),"currentPos")), []));

    var recurse = function(e){ 
      path.push(e);
      var r = expr_to_ast_creating_expr(path, patchFun);
      path.pop();
      return r;
    };
    var dummy_p = Context.currentPos();  //{ file: "Macrox.hx", min: 2, max: 2};
    var t = e.typeof();
    var r = switch (t){
      case TObject:
        (EObjectDecl(e.mapFields(function(f, fe){
          return {
            field: f,
            expr: recurse(fe)
          };
        }))).at();

      case TUnknown:
        if ((""+e).substr(0,4) == "#pos") {
          if (true){
          ast_curr_pos;
          } else {
            // TODO
            // with_p(ECall(with_p(EField(with_p(EType(with_p(EField(with_p(EConst(CIdent("haxe"))),"macro")),"Context")),"currentPos")), []))
            var r = ~/#pos\(([^:]*):([0-9]+): characters ([0-9]+)-([0-9]+)/;
            r.match(e+"");
            var p = {file: r.matched(1), min: r.matched(2).parseInt(), max: r.matched(3).parseInt()};
            trace(p);
            recurse(p);
          }
        } else {
          throw "unkown thing: "+e +" fields: "+ e.fields();
        }
      case TInt:
        EConst(CInt(e)).at(dummy_p);

      case TClass(c):
        if (e.is(String))
          EConst(CString(e)).at(dummy_p)
        else if (e.is(Array)){
         EArrayDecl(map_a(e, recurse)).at(dummy_p);
        } else throw "TODO type: "+t+" value: "+e;

      case TNull:
        return EConst(CIdent("null")).at(dummy_p);

      case TEnum(ee):
        var tenum_name = ee.getEnumName();
        var ep = e.enumParameters();
        var name = ee.getEnumConstructs()[e.enumIndex()];
        ECall(name.resolve_identifier(), map_a(ep, recurse)).at(dummy_p);

      default:
        throw "TODO type: "+t;
    }
//     trace(e);
//     trace('got');
//     trace(r);
    return r;
  }

  static public function show(msg, exp){
    // trace(msg);
    // trace(exp);
    // trace(scuts.macro.Print.exprStr(exp));
  }

  static public function ast_replace_place_holders(path:Array<Dynamic>, len:Int):Null<Dynamic>{
    var h = path[len-1];
    var is_var = Util.ast_value(h, ["EConst",0,"CIdent",0]);
    if (is_var != null && is_var.substr(0,3) == "e__"){
        // for (p in path){
        //   trace("parent >>:");
        //   trace(p);
        // }
        var n = is_var.substr(3,null);
        return EConst(CIdent(n)).at();
        trace("new name "+n);
        return expr_to_ast_creating_expr([EConst(CIdent("a"))], null);
    }
    return null;
  }

  @:macro static public function build(e:Expr){
    var r = expr_to_ast_creating_expr([e], ast_replace_place_holders);
    show("ast creating ast: ", r);
    // trace(scuts.macro.Print.exprStr(r));
    show("ast creating ast: ", r);
    return r;
  }

  @:macro static public function test(){
    /*
          var name = 'foo';
          AST.build({
              var ___name = 5;
              ___name = 6;
        })
    */

    var int_10 = build(10).expr;
    var foo = "my_var";

    var r: Dynamic = build([ //<< this tests array
        // int by substitution
        e__int_10
        , // int
        2
        , // float
        2.2
        , // string
        "string"
        , // null
        null
        , // object
        { a: "a" }
        , // anonymous function
        function(){ return 7;}
        , // anonymous function with var (this fails unless you patch HaXe, Macro bug
//         function(){ 
//           var foo = 8;
//           return foo;
//         }

    //     , // anonymous function with var, fails due to HaXe macro compiler bug ?
    //     function(){ 
    //       var fooX = 8;
    //       return fooX;
    //     },


//         , // block tset, assign C (outer scope), then return 11
//         {
//           var C = 8;
//           return 11;
//         }

    ]);

    // var r = build({
    //     var ___name = 5;
    //     ___name = 6;
    // });

    // WTF: why do I need this dummy r2 to prevent a  
    // ./macrox/Macrox.hx|153| lines 153-173 : Duplicate field in object declaration : null
    // failure !???
    var r_dummy = EArrayDecl([ EFunction(null,{ ret: null, args : [], expr : EBlock([EReturn( EConst(CInt("7")).at()).at()]).at() , params : [] }).at()]).at();
    // if (r2+"" != r+"")
    //   trace("bad!");
    // var r = haxe.Unserializer.run(haxe.Serializer.run(r));
    return r;
  }

}


