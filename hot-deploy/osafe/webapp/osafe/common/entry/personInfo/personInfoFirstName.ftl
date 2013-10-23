<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#if person?has_content>
  <#assign firstName= person.firstName!""/>
</#if>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
      <label for="USER_FIRST_NAME"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.FirstNameCaption}</label>
      <input type="text" maxlength="100" name="USER_FIRST_NAME" id="js_USER_FIRST_NAME" value="${requestParameters.USER_FIRST_NAME!firstName!""}" />
      <input type="hidden" name="USER_FIRST_NAME_MANDATORY" value="${mandatory}"/>
      <@fieldErrors fieldName="USER_FIRST_NAME"/>
</div>