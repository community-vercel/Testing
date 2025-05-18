const Stripe = require('stripe');
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json'),
});
const db = admin.firestore();
const stripe = new Stripe('sk_test_51AfCnUJe629jCerG6cwy5wfbS1BIe3IutGdznoVV57kzBUkJxznnU0C7RBH37oqWCUbM9ZFRm68bA8Ohjz7PoQv900C0KApFmU');

async function createConnectAccount(email, role) {
  try {
    const account = await stripe.accounts.create({
      type: 'express',
      email: email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
    });
    console.log(`Created ${role} account: ${account.id}`);
    return account.id;
  } catch (error) {
    console.error(`Error creating ${role} account:`, error);
    throw error;
  }
}

async function createTransfers(paymentIntentId, amount, sellerAccountId, ownerAccountId) {
  try {
    const sellerAmount = Math.floor(amount * 0.9); // 90%
    const ownerAmount = amount - sellerAmount; // 10%

    // Transfer to seller
    await stripe.transfers.create({
      amount: sellerAmount,
      currency: 'usd',
      destination: sellerAccountId,
      source_transaction: paymentIntentId,
    });

    // Transfer to owner
    await stripe.transfers.create({
      amount: ownerAmount,
      currency: 'usd',
      destination: ownerAccountId,
      source_transaction: paymentIntentId,
    });

    console.log('Transfers created successfully');
  } catch (error) {
    console.error('Error creating transfers:', error);
    throw error;
  }
}

async function processPendingTransactions() {
  const transactions = await db.collection('transactions')
    .where('status', '==', 'completed')
    .where('transferred', '==', false)
    .get();

  for (const doc of transactions.docs) {
    const data = doc.data();
    const paymentIntentId = data.paymentIntentId; // Assume stored during payment
    const amount = data.amount * 100; // Convert to cents
    const sellerId = data.sellerId;
    const ownerId = data.ownerId;

    const sellerDoc = await db.collection('users').doc(sellerId).get();
    const ownerDoc = await db.collection('users').doc(ownerId).get();
    const sellerAccountId = sellerDoc.data().stripeAccountId;
    const ownerAccountId = ownerDoc.data().stripeAccountId;

    await createTransfers(paymentIntentId, amount, sellerAccountId, ownerAccountId);
    await doc.ref.update({ transferred: true });
  }
}

async function setupUsers() {
  const sellerEmail = 'seller@example.com';
  const ownerEmail = 'owner@example.com';

  const sellerAccountId = await createConnectAccount(sellerEmail, 'seller');
  const ownerAccountId = await createConnectAccount(ownerEmail, 'owner');

  await db.collection('users').doc('seller_user_id').set({
    email: sellerEmail,
    role: 'seller',
    stripeAccountId: sellerAccountId,
  });
  await db.collection('users').doc('owner_user_id').set({
    email: ownerEmail,
    role: 'owner',
    stripeAccountId: ownerAccountId,
  });

  console.log('Users set up successfully');
}

setupUsers().then(() => processPendingTransactions()).catch(console.error);