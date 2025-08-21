// Wrapper for useInstantAuth that handles null db gracefully
export const useInstantAuth = ({
  db,
  sessionData,
  isPending,
}: {
  db: unknown;
  sessionData: unknown;
  isPending: boolean;
}) => {
  // If db is null (env vars not set), return early
  if (!db) {
    return;
  }

  // Only import and use the actual hook if db exists
  const {
    useInstantAuth: actualHook,
  } = require('@daveyplate/better-auth-instantdb');
  return actualHook({ db, sessionData, isPending });
};
