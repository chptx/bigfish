<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
      <label for="firstName"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.FirstNameCaption}</label>
      <input type="text" maxlength="100" name="firstName" id="firstName" value="${parameters.firstName!firstName!""}"/>
      <input type="hidden" name="firstName_MANDATORY" value="${mandatory}"/>
      <@fieldErrors fieldName="firstName"/>
</div>