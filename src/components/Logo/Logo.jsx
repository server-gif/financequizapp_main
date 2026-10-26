/**
 * FinanceQuizApp brand mark — a graduation cap, ascending growth bars and a
 * rupee coin on a rounded forest tile. The tile is baked into the PNG so the
 * header, the footer and the loading splash in index.html all render the exact
 * same artwork from a single cached request.
 */
const MARK = '/images/brand/financequizapp-logo.png';

export default function Logo({ className = '' }) {
  return (
    <img
      className={className}
      src={MARK}
      alt=""
      width="320"
      height="320"
      aria-hidden="true"
      decoding="async"
    />
  );
}
