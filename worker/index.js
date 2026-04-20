// Greenwire Portal API Worker
// Handles secure API calls to Syncro, Huntress, ThreatLocker, Slide

const SYNCRO_API_KEY = ''; // Add your Syncro API key
const HUNTRESS_API_KEY = ''; // Add your Huntress API key  
const THREATLOCKER_API_KEY = ''; // Add your ThreatLocker API key
const SLIDE_API_KEY = ''; // Add your Slide API key

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

async function handleRequest(request) {
  const url = new URL(request.url);
  const path = url.pathname;

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    if (path === '/api/tickets') {
      return await getSyncroTickets();
    } else if (path === '/api/huntress') {
      return await getHuntressAlerts();
    } else if (path === '/api/threatlocker') {
      return await getThreatLockerRequests();
    } else if (path === '/api/slide') {
      return await getSlideBackups();
    } else if (path === '/api/health') {
      return json({ status: 'ok' });
    } else {
      return json({ error: 'Not found' }, 404);
    }
  } catch (e) {
    return json({ error: e.message }, 500);
  }
}

async function getSyncroTickets() {
  if (!SYNCRO_API_KEY) {
    return json({ tickets: [], error: 'Syncro API key not configured' });
  }

  try {
    const res = await fetch('https://api.syncromsp.com/api/v1/tickets?status=open&per_page=10', {
      headers: {
        'Authorization': SYNCRO_API_KEY,
        'Content-Type': 'application/json',
      },
    });
    
    if (!res.ok) {
      return json({ tickets: [], error: `Syncro error: ${res.status}` });
    }
    
    const data = await res.json();
    return json({ tickets: (data.tickets || data).slice(0, 10) });
  } catch (e) {
    return json({ tickets: [], error: e.message });
  }
}

async function getHuntressAlerts() {
  if (!HUNTRESS_API_KEY) {
    return json({ alerts: [], error: 'Huntress API key not configured' });
  }

  try {
    const res = await fetch('https://dashboard.huntress.io/api/v1/alerts?status=active', {
      headers: {
        'Authorization': `Bearer ${HUNTRESS_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    
    if (!res.ok) {
      return json({ alerts: [], error: `Huntress error: ${res.status}` });
    }
    
    const data = await res.json();
    return json({ alerts: (data.alerts || []).slice(0, 10) });
  } catch (e) {
    return json({ alerts: [], error: e.message });
  }
}

async function getThreatLockerRequests() {
  if (!THREATLOCKER_API_KEY) {
    return json({ requests: [], error: 'ThreatLocker API key not configured' });
  }

  try {
    const res = await fetch('https://api.threatlocker.com/v1/requests?status=pending', {
      headers: {
        'Authorization': `Bearer ${THREATLOCKER_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    
    if (!res.ok) {
      return json({ requests: [], error: `ThreatLocker error: ${res.status}` });
    }
    
    const data = await res.json();
    return json({ requests: (data.requests || data).slice(0, 10) });
  } catch (e) {
    return json({ requests: [], error: e.message });
  }
}

async function getSlideBackups() {
  if (!SLIDE_API_KEY) {
    return json({ failed: [], offline: [], error: 'Slide API key not configured' });
  }

  try {
    // Slide API - get agents/devices
    const res = await fetch('https://api.slide.tech/v1/devices', {
      headers: {
        'Authorization': `Bearer ${SLIDE_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    
    if (!res.ok) {
      return json({ failed: [], offline: [], error: `Slide error: ${res.status}` });
    }
    
    const data = await res.json();
    const devices = data.devices || data || [];
    
    // Filter failed and offline
    const failed = devices.filter(d => d.backup_status === 'failed' || d.status === 'failed');
    const offline = devices.filter(d => d.backup_status === 'offline' || d.status === 'offline' || d.online === false);
    
    return json({ failed: failed.slice(0, 10), offline: offline.slice(0, 10) });
  } catch (e) {
    return json({ failed: [], offline: [], error: e.message });
  }
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

addEventListener('fetch', (event) => {
  event.respondWith(handleRequest(event.request));
});
