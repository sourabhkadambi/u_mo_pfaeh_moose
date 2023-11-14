#include "UMoPFAEHMooseApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
UMoPFAEHMooseApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

UMoPFAEHMooseApp::UMoPFAEHMooseApp(InputParameters parameters) : MooseApp(parameters)
{
  UMoPFAEHMooseApp::registerAll(_factory, _action_factory, _syntax);
}

UMoPFAEHMooseApp::~UMoPFAEHMooseApp() {}

void 
UMoPFAEHMooseApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<UMoPFAEHMooseApp>(f, af, s);
  Registry::registerObjectsTo(f, {"UMoPFAEHMooseApp"});
  Registry::registerActionsTo(af, {"UMoPFAEHMooseApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
UMoPFAEHMooseApp::registerApps()
{
  registerApp(UMoPFAEHMooseApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
UMoPFAEHMooseApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  UMoPFAEHMooseApp::registerAll(f, af, s);
}
extern "C" void
UMoPFAEHMooseApp__registerApps()
{
  UMoPFAEHMooseApp::registerApps();
}
