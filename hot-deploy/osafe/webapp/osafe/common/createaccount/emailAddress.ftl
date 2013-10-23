<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
    <div class="entry userLogin">
        <label for= "CUSTOMER_EMAIL"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.EmailAddressCaption}</label>
        <input type="email"  maxlength="100" class="emailAddress" name="CUSTOMER_EMAIL" id="js_CUSTOMER_EMAIL" value="${requestParameters.CUSTOMER_EMAIL!requestParameters.USERNAME!requestParameters.USERNAME_NEW!}" onchange="changeEmail();" maxlength="255"/>
        <span class="entryHelper">${uiLabelMap.EmailAddressInstructionsInfo}</span>
        <input type="hidden" name="UNUSEEMAIL" id="UNUSEEMAIL" value="on" />
        <input type="hidden" name="USERNAME" id="js_USERNAME" value="${requestParameters.USERNAME?if_exists}" maxlength="255"/>
        <input type="hidden" id="CUSTOMER_EMAIL_MANDATORY" name="CUSTOMER_EMAIL_MANDATORY" value="${mandatory}"/>
        <@fieldErrors fieldName="CUSTOMER_EMAIL"/>
    </div>
</div>