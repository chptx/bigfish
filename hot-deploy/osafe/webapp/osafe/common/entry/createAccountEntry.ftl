<#if !userLogin?has_content || userLogin.userLoginId == "anonymous">
<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign partyDBAllowSolicit=allowSolicitation!""/>
<#assign partyDBEmailPref=partyEmailPreference!""/>
<div id="createAccountEntry" class="displayBox">
<h3>${uiLabelMap.CreateAnAccountHeading}</h3>
<span class="boxTopMessage">${uiLabelMap.CreateAccountInfo}</span>
    <div class="entry userName">
      <label for="CUSTOMER_EMAIL">${uiLabelMap.EmailAddressShortCaption}</label>
      <input type="text"  maxlength="100" class="emailAddress" name="CUSTOMER_EMAIL" id="js_CUSTOMER_EMAIL" value="${requestParameters.CUSTOMER_EMAIL!requestParameters.USERNAME!requestParameters.USERNAME_GUEST!userEmailAddress!}" onchange="changeEmail();" maxlength="255" readonly=readonly/>
      <input type="hidden" name="UNUSEEMAIL" id="UNUSEEMAIL" value="on" />
      <input type="hidden" name="USERNAME" id="js_USERNAME" value="${requestParameters.USERNAME?if_exists}" maxlength="255"/>
      <@fieldErrors fieldName="CUSTOMER_EMAIL"/>
    </div>
    <#if !userLogin?has_content || userLogin.userLoginId == "anonymous">
      <div class="entry userPassword">
        <label for="PASSWORD">${uiLabelMap.EnterPasswordCaption}</label>
        <input type="password"  maxlength="60" class="password" name="PASSWORD"  id="PASSWORD" value="${requestParameters.PASSWORD?if_exists}" maxlength="50"/>
        <@fieldErrors fieldName="PASSWORD"/>
      </div>

      <div class="entry userPasswordConfirm">
        <label for="CONFIRM_PASSWORD">${uiLabelMap.RepeatPasswordCaption}</label>
        <input type="password"  maxlength="60" name="CONFIRM_PASSWORD" id="CONFIRM_PASSWORD" class="password" value="${requestParameters.CONFIRM_PASSWORD?if_exists}" maxlength="50"/>
        <@fieldErrors fieldName="CONFIRM_PASSWORD"/>
      </div>
    </#if>

      <#assign partyAllowSolicit=parameters.CUSTOMER_EMAIL_ALLOW_SOL!""/>
      <#if partyAllowSolicit?has_content && partyAllowSolicit == "Y">
        <#assign partyAllowSolicitChecked="checked"/>
      <#else>
        <#assign partyAllowSolicitChecked=""/>
      </#if>

      <div class="entry userAllowSolicitation">
        <input type="checkbox" id="CUSTOMER_EMAIL_ALLOW_SOL" name="CUSTOMER_EMAIL_ALLOW_SOL" value="Y" ${partyAllowSolicitChecked!""}/><span class="radioOptionText">${uiLabelMap.RegistrationSolicitCheckboxLabel}</span>
        <@fieldErrors fieldName="PARTY_SOLICIT"/>
      </div>

      <#assign partyEmailPref=parameters.PARTY_EMAIL_PREFERENCE!partyDBEmailPref!""/>
      <#assign partyEmailPreferenceHtml="checked"/>
      <#assign partyEmailPreferenceText=""/>
      <#if partyEmailPref?has_content>
        <#if partyEmailPref == "HTML">
          <#assign partyEmailPreferenceHtml="checked"/>
        <#else>
           <#assign partyEmailPreferenceHtml=""/>
           <#assign partyEmailPreferenceText="checked"/>
        </#if>
      </#if>
      <div class="entry userEmailPreferenceHtml">
        <input type="radio" id="PARTY_EMAIL_HTML" name="PARTY_EMAIL_PREFERENCE" value="HTML" ${partyEmailPreferenceHtml!""}/><span class="radioOptionText">${uiLabelMap.RegistrationEmailPreferenceHtmlLabel}</span>
      </div>
      <div class="entry userEmailPreferenceTxt">
        <input type="radio" id="PARTY_EMAIL_TEXT" name="PARTY_EMAIL_PREFERENCE" value="TEXT" ${partyEmailPreferenceText!""}/><span class="radioOptionText">${uiLabelMap.RegistrationEmailPreferenceTextLabel}</span>
      </div>
</div>
</#if>