//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "UMoPFAEHMooseTestApp.h"
#include "UMoPFAEHMooseApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
UMoPFAEHMooseTestApp::validParams()
{
  InputParameters params = UMoPFAEHMooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

UMoPFAEHMooseTestApp::UMoPFAEHMooseTestApp(InputParameters parameters) : MooseApp(parameters)
{
  UMoPFAEHMooseTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

UMoPFAEHMooseTestApp::~UMoPFAEHMooseTestApp() {}

void
UMoPFAEHMooseTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  UMoPFAEHMooseApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"UMoPFAEHMooseTestApp"});
    Registry::registerActionsTo(af, {"UMoPFAEHMooseTestApp"});
  }
}

void
UMoPFAEHMooseTestApp::registerApps()
{
  registerApp(UMoPFAEHMooseApp);
  registerApp(UMoPFAEHMooseTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
UMoPFAEHMooseTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  UMoPFAEHMooseTestApp::registerAll(f, af, s);
}
extern "C" void
UMoPFAEHMooseTestApp__registerApps()
{
  UMoPFAEHMooseTestApp::registerApps();
}
