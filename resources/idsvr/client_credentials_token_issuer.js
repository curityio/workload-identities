/**
 * @param {se.curity.identityserver.procedures.context.ClientCredentialsTokenProcedureContext} context
 */
function result(context) {
  var delegationData = context.getDefaultDelegationData();
  var issuedDelegation = context.delegationIssuer.issue(delegationData);

  var issuerType = context.client.properties['at_issuer'];
  var tokenIssuer = issuerType === 'jwt' ? context.getDefaultAccessTokenJwtIssuer() : context.accessTokenIssuer;

  var accessTokenData = context.getDefaultAccessTokenData();
  var issuedAccessToken = tokenIssuer.issue(accessTokenData, issuedDelegation);

  return {
    scope: accessTokenData.scope,
    access_token: issuedAccessToken,
    token_type: 'bearer',
    expires_in: secondsUntil(accessTokenData.exp),
  };
}
