<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
    <#assign partyDBEmailPref=partyEmailPreference!""/>
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
        <label for="PARTY_EMAIL_PREFERENCE"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.EmailMessageNotificationsCaption}</label>
        <input type="radio" id="PARTY_EMAIL_HTML" name="PARTY_EMAIL_PREFERENCE" value="HTML" ${partyEmailPreferenceHtml!""}/><span class="radioOptionText">${uiLabelMap.RegistrationEmailPreferenceHtmlLabel}</span>
    </div>
    <div class="entry userEmailPreferenceTxt">
        <label>&nbsp;</label>
        <input type="radio" id="PARTY_EMAIL_TEXT" name="PARTY_EMAIL_PREFERENCE" value="TEXT" ${partyEmailPreferenceText!""}/><span class="radioOptionText">${uiLabelMap.RegistrationEmailPreferenceTextLabel}</span>
    </div>
    <@fieldErrors fieldName="PARTY_EMAIL_PREFERENCE"/>
    <input type="hidden" id="PARTY_EMAIL_PREFERENCE_MANDATORY" name="PARTY_EMAIL_PREFERENCE_MANDATORY" value="${mandatory}"/>
</div>