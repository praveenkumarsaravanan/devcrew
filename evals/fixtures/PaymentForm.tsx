import React, { useState } from 'react';

interface Props {
  onSubmit: (data: FormData) => void;
}

interface FormData {
  name: string;
  email: string;
  creditCard: string;
  cvv: string;
}

// BUG 1 (CRITICAL - PII in console): Logs sensitive data
// BUG 2 (HIGH - XSS): dangerouslySetInnerHTML with user input
// BUG 3 (MEDIUM - No input sanitization): Raw input passed to callback
// BUG 4 (MEDIUM - Accessibility): Missing labels and ARIA attributes
// BUG 5 (LOW - Performance): Re-renders on every keystroke without debounce

export const PaymentForm: React.FC<Props> = ({ onSubmit }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [creditCard, setCreditCard] = useState('');
  const [cvv, setCvv] = useState('');
  const [message, setMessage] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // BUG 1: Logging PII to console
    console.log('Payment submitted:', { name, email, creditCard, cvv });

    // BUG 3: No sanitization
    onSubmit({ name, email, creditCard, cvv });

    setMessage(`Thank you, ${name}! Payment for card ending in ${creditCard.slice(-4)} processed.`);
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* BUG 4: No <label> elements, no aria attributes */}
      <input
        type="text"
        placeholder="Full Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />
      <input
        type="text"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="text"
        placeholder="Credit Card Number"
        value={creditCard}
        onChange={(e) => setCreditCard(e.target.value)}
      />
      <input
        type="text"
        placeholder="CVV"
        value={cvv}
        onChange={(e) => setCvv(e.target.value)}
      />

      {/* BUG 2: XSS via dangerouslySetInnerHTML */}
      {message && <div dangerouslySetInnerHTML={{ __html: message }} />}

      <button type="submit">Pay Now</button>
    </form>
  );
};
