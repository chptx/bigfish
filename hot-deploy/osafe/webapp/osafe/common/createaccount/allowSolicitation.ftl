<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
     <#assign partyDBAllowSolicit=allowSolicitation!""/>
     <#assign partyAllowSolicit=parameters.CUSTOMER_EMAIL_ALLOW_SOL!""/>
     <#if partyAllowSolicit?has_content && partyAllowSolicit == "Y">
         <#assign partyAllowSolicitChecked="checked"/>
     <#else>
         <#assign partyAllowSolicitChecked=""/>
     </#if>
    <div class="entry userAllowSolicitation">
        <label>&nbsp;</label>
        <input type="checkbox" id="CUSTOMER_EMAIL_ALLOW_SOL" name="CUSTOMER_EMAIL_ALLOW_SOL" value="Y" ${partyAllowSolicitChecked!""}/><span class="radioOptionText">${uiLabelMap.RegistrationSolicitCheckboxLabel}</span>
        <input type="hidden" id="CUSTOMER_EMAIL_ALLOW_SOL_MANDATORY" name="CUSTOMER_EMAIL_ALLOW_SOL_MANDATORY" value="${mandatory}"/>
        <@fieldErrors fieldName="CUSTOMER_EMAIL_ALLOW_SOL"/>
    </div>
</div>