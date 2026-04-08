# Legal & Support Documents

This folder contains source content for Estaraht’s **Privacy Policy** and **Delete Account** pages.

## Using with Google Docs

1. **Create a new Google Doc** for each page:
   - [Google Docs](https://docs.google.com) → **Blank** or **New** → **Google Docs**.

2. **Copy the content:**
   - Open `PRIVACY_POLICY.md` or `DELETE_ACCOUNT.md` in any editor.
   - Copy all text (you can keep headings and lists; Google Docs will format them).

3. **Paste into the Doc** and adjust:
   - Replace placeholders like `[Add date]` with the real last-updated date.
   - Use **Format → Paragraph styles** (e.g. Title, Heading 1, Heading 2) for the titles and sections.
   - Add your logo or branding at the top if you like.

4. **Publish or share:**
   - **File → Share → Publish to web** to get a link you can use as your Privacy Policy or Delete Account URL.
   - Or **File → Download** as PDF/HTML and host on your website (e.g. estaraht.com/privacy-policy and estaraht.com/delete-account).

## App URLs

Point the app to your published pages by updating:

- `lib/core/constants/app_urls.dart`
  - `AppUrls.privacyPolicy` → e.g. your published Privacy Policy URL
  - `AppUrls.deleteAccount` → e.g. your published Delete Account URL

## Files

| File               | Purpose |
|--------------------|--------|
| `PRIVACY_POLICY.md`| Full privacy policy for the Estaraht apps. |
| `DELETE_ACCOUNT.md`| Instructions and options for deleting an account and data. |
| `README.md`        | This file — how to use these docs with Google Docs. |

Update the markdown files when you change the policy or delete-account process; then refresh the Google Docs (or web pages) so the app and your published pages stay in sync.
