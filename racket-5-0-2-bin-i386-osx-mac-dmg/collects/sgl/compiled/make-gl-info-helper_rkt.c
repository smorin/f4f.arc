#include <escheme.h>
#include <GL/gl.h>
#include <GL/glu.h>

Scheme_Object *scheme_reload(Scheme_Env *env)
{
  Scheme_Env *mod_env;

  mod_env = scheme_primitive_module(scheme_intern_symbol("make-gl-info-helper"), env);
  scheme_add_global("gl-byte-size",
                    scheme_make_integer_value(sizeof(GLbyte)),
                    mod_env);
  scheme_add_global("gl-ubyte-size",
                    scheme_make_integer_value(sizeof(GLubyte)),
                    mod_env);
  scheme_add_global("gl-short-size",
                    scheme_make_integer_value(sizeof(GLshort)),
                    mod_env);
  scheme_add_global("gl-ushort-size",
                    scheme_make_integer_value(sizeof(GLushort)),
                    mod_env);
  scheme_add_global("gl-int-size",
                    scheme_make_integer_value(sizeof(GLint)),
                    mod_env);
  scheme_add_global("gl-uint-size",
                    scheme_make_integer_value(sizeof(GLuint)),
                    mod_env);
  scheme_add_global("gl-float-size",
                    scheme_make_integer_value(sizeof(GLfloat)),
                    mod_env);
  scheme_add_global("gl-double-size",
                    scheme_make_integer_value(sizeof(GLdouble)),
                    mod_env);
  scheme_add_global("gl-boolean-size",
                    scheme_make_integer_value(sizeof(GLboolean)),
                    mod_env);
  scheme_add_global("gl-sizei-size",
                    scheme_make_integer_value(sizeof(GLsizei)),
                    mod_env);
  scheme_add_global("gl-clampf-size",
                    scheme_make_integer_value(sizeof(GLclampf)),
                    mod_env);
  scheme_add_global("gl-clampd-size",
                    scheme_make_integer_value(sizeof(GLclampd)),
                    mod_env);
  scheme_add_global("gl-enum-size",
                    scheme_make_integer_value(sizeof(GLenum)),
                    mod_env);
  scheme_add_global("gl-bitfield-size",
                    scheme_make_integer_value(sizeof(GLbitfield)),
                    mod_env);
  scheme_finish_primitive_module(mod_env);

  return scheme_void;
}

Scheme_Object *scheme_initialize(Scheme_Env *env)
{
  return scheme_reload(env);
}

Scheme_Object *scheme_module_name(void)
{
  return scheme_intern_symbol("make-gl-info-helper");
}
